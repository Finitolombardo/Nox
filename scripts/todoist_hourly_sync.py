#!/usr/bin/env python3
import json
import os
from pathlib import Path
import requests

NOTION_DS = "18309df6-e88e-808f-a5fe-000b310df88b"  # Quests
MAP_PATH = Path('/home/agentadmin/.openclaw/workspace/memory/notion_todoist_map.json')
TOKEN_PATH = Path('/root/.config/todoist/api_token')
CFG_PATH = Path('/root/.openclaw/openclaw.json')


def load_tokens():
    todo = TOKEN_PATH.read_text().strip()
    cfg = json.loads(CFG_PATH.read_text())
    notion = cfg.get('skills', {}).get('entries', {}).get('notion', {}).get('apiKey') or cfg.get('env', {}).get('vars', {}).get('NOTION_API_KEY')
    if not notion:
        raise RuntimeError('Notion API key missing')
    return todo, notion


def notion_query(notion_key):
    h = {
        'Authorization': f'Bearer {notion_key}',
        'Notion-Version': '2025-09-03',
        'Content-Type': 'application/json',
    }
    r = requests.post(f'https://api.notion.com/v1/data_sources/{NOTION_DS}/query', headers=h, json={'page_size': 200}, timeout=30)
    r.raise_for_status()
    return r.json().get('results', [])


def extract_title(props):
    for _, v in props.items():
        if v.get('type') == 'title':
            return ''.join(t.get('plain_text', '') for t in v.get('title', []))
    return ''


def todo_get_open(todo_token):
    r = requests.get('https://api.todoist.com/api/v1/tasks', headers={'Authorization': f'Bearer {todo_token}'}, timeout=30)
    r.raise_for_status()
    data = r.json()
    return data.get('results', data if isinstance(data, list) else [])


def todo_create(todo_token, content, description, priority):
    r = requests.post('https://api.todoist.com/api/v1/tasks',
                      headers={'Authorization': f'Bearer {todo_token}', 'Content-Type': 'application/json'},
                      json={'content': content, 'description': description, 'priority': priority}, timeout=30)
    r.raise_for_status()
    return r.json()['id']


def todo_update(todo_token, task_id, description=None, priority=None):
    body = {}
    if description is not None:
        body['description'] = description
    if priority is not None:
        body['priority'] = priority
    if not body:
        return
    r = requests.post(f'https://api.todoist.com/api/v1/tasks/{task_id}',
                      headers={'Authorization': f'Bearer {todo_token}', 'Content-Type': 'application/json'},
                      json=body, timeout=30)
    r.raise_for_status()


def todo_close(todo_token, task_id):
    r = requests.post(f'https://api.todoist.com/api/v1/tasks/{task_id}/close', headers={'Authorization': f'Bearer {todo_token}'}, timeout=30)
    if r.status_code not in (204, 200):
        r.raise_for_status()


def pmap(notion_prio):
    # notion 1 high -> todoist 4 high
    if notion_prio == 1:
        return 4
    if notion_prio == 2:
        return 3
    if notion_prio == 3:
        return 2
    return 1


def main():
    todo_token, notion_key = load_tokens()
    MAP_PATH.parent.mkdir(parents=True, exist_ok=True)
    mapping = json.loads(MAP_PATH.read_text()) if MAP_PATH.exists() else {}

    open_tasks = todo_get_open(todo_token)
    by_content = {t['content']: t for t in open_tasks}

    pages = notion_query(notion_key)
    handled = 0

    for p in pages:
        props = p.get('properties', {})
        title = extract_title(props).strip()
        if not title:
            continue
        status = (props.get('Status', {}).get('status') or {}).get('name', 'Ausstehend')
        prio = props.get('Prio', {}).get('number') if props.get('Prio', {}).get('type') == 'number' else 3
        typ = (props.get('Typ', {}).get('select') or {}).get('name', '')
        # only sync strategic work
        if typ not in ('Umsatz', 'Business'):
            continue

        content = f"[NQ] {title}"
        desc = f"Notion: {p.get('url')} | Status: {status}"
        todo_prio = pmap(prio)
        task_id = mapping.get(p['id'])

        if status == 'Erledigt':
            if task_id:
                try:
                    todo_close(todo_token, task_id)
                except Exception:
                    pass
                mapping.pop(p['id'], None)
            elif content in by_content:
                try:
                    todo_close(todo_token, by_content[content]['id'])
                except Exception:
                    pass
            handled += 1
            continue

        # active/pending
        if task_id:
            try:
                todo_update(todo_token, task_id, description=desc, priority=todo_prio)
                handled += 1
                continue
            except Exception:
                mapping.pop(p['id'], None)

        if content in by_content:
            tid = by_content[content]['id']
            mapping[p['id']] = tid
            todo_update(todo_token, tid, description=desc, priority=todo_prio)
            handled += 1
        else:
            tid = todo_create(todo_token, content, desc, todo_prio)
            mapping[p['id']] = tid
            handled += 1

    MAP_PATH.write_text(json.dumps(mapping, indent=2))
    print(f"SYNC_OK handled={handled} mapped={len(mapping)}")


if __name__ == '__main__':
    main()

# Updated Logic to Manage Active Quests
# Ensuring that no more than 10 active quests are allowed

MAX_ACTIVE = 10

class DB:
    @staticmethod
    def read():
        ensure_lockfile()
        with open(LOCK_FILE, 'r', encoding='utf-8') as lf:
            fcntl.flock(lf, fcntl.LOCK_SH)
            try:
                db = load_db_unlocked()
                # Check active quests limit
                active_count = sum(1 for q in db['quests'] if q['status'] in ACTIVE_STATUSES)
                if active_count >= MAX_ACTIVE:
                    return 409, {'error': 'Active quest limit reached.'}
                return 200, db
            finally:
                fcntl.flock(lf, fcntl.LOCK_UN)
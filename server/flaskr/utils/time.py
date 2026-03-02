from datetime import datetime

def time_to_string(time: datetime) -> str:
    return time.isoformat()

def time_now_to_string()-> str:
    return time_to_string(datetime.now())

def string_to_time(time: str) -> datetime | None:
    try:
        return datetime.fromisoformat(time)
    except:
        return None
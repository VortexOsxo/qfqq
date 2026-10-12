from datetime import timedelta


def format_duration(duration: timedelta, locale: str) -> str:
    total_seconds = int(duration.total_seconds())
    units = (
        (86400, ("day", "days"), ("jour", "jours")),
        (3600, ("hour", "hours"), ("heure", "heures")),
        (60, ("minute", "minutes"), ("minute", "minutes")),
        (1, ("second", "seconds"), ("seconde", "secondes")),
    )
    language_index = 0 if locale == "en" else 1
    remaining = abs(total_seconds)
    parts = []

    for unit_seconds, english, french in units:
        count, remaining = divmod(remaining, unit_seconds)
        if count:
            singular, plural = (english, french)[language_index]
            parts.append(f"{count} {singular if count == 1 else plural}")

    if not parts:
        parts.append("0 seconds" if language_index == 0 else "0 seconde")

    return " ".join(parts)

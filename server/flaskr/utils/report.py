import ast

def get_report_name(args):
    name = args.get("name", "unnamed", type=str)
    return name[:30] if name else "unnamed"

def get_report_filter(args) -> dict:
    filters = {}
    if not args: return filters

    # If pattern used to refuse empty values such as 0,"", etc.
    if projectId := args.get("projectId", None, type=int):
        filters["projectId"] = projectId
    if responsibleId := args.get("responsibleId", None, type=int):
        filters["responsibleId"] = responsibleId
    if status := args.get("status", None, type=str):
        filters["status"] = status
    return filters

def get_report_column(args, default) -> set[int]:
    try:
        value = args.get("columns")
        columns = ast.literal_eval(value)
        if isinstance(columns, set) and all(isinstance(column, int) for column in columns):
            return columns
    except Exception as e: print(e)
    return set(default)

def get_report_show_reviews(args):
    return args.get("showComments", "false").lower() == "true"
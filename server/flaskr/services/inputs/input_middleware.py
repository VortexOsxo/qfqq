from functools import wraps
from flask import request, jsonify

def input_middleware(input_builder):
    def validate(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            data = request.get_json() or {}

            result, obj = input_builder.build(data)
            if not result: 
                return jsonify(obj), 400
 
            return f(*args, **(kwargs | obj))
        return decorated
    return validate
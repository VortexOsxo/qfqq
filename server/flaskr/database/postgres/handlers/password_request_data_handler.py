from ..postgres import read_query, get_db_access


class PasswordRequestDataHandler:
    @classmethod
    def create_request(cls, email: str, code: str, time: str) -> bool:
        try:
            with get_db_access() as conn:
                cur = conn.cursor()
                cur.execute("DELETE FROM passwordRequests WHERE email = %s", (email,))

                query = "INSERT INTO passwordRequests (email, code, date) values (%s, %s, %s);"
                params = (email, code, time)
                cur.execute(query, params)
            return True
        except:
            pass
        return False

    @classmethod
    def get_date(cls, email: str, code: str) -> str | None:
        query = "SELECT date FROM passwordRequests WHERE email = %s AND code = %s;"
        params = (email, code)
        
        values = read_query(query, params)
        if len(values) == 0 or len(values[0]) != 1: return None
        return values[0][0]

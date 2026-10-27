from ..postgres import read_query, get_db_access


class EmailValidationDataHandler:
    @classmethod
    def create_request(cls, email: str, code: str) -> bool:
        try:
            with get_db_access() as conn:
                cur = conn.cursor()
                query = """
                    INSERT INTO public.emailVerificationRequests (email, code)
                    VALUES (%s, %s)
                    ON CONFLICT (email)
                    DO UPDATE SET code = EXCLUDED.code;
                """
                params = (email, code)
                cur.execute(query, params)
            return True
        except:
            pass
        return False

    @classmethod
    def validate_request(cls, email: str, code: str) -> bool:
        query = "SELECT 1 FROM public.emailVerificationRequests WHERE email = %s AND code = %s;"
        params = (email, code)

        values = read_query(query, params)
        return len(values) != 0

    @classmethod
    def delete_request(cls, email: str) -> bool:
        with get_db_access() as conn:
            cur = conn.cursor()
            query = "DELETE FROM public.emailVerificationRequests WHERE email = %s;"
            cur.execute(query, (email,))

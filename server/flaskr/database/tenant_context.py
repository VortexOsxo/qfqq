from contextvars import ContextVar
from contextlib import contextmanager
from typing import Optional

_tenant_org_id: ContextVar[Optional[str]] = ContextVar("tenant_slug", default=None)

@contextmanager
def use_tenant(id: Optional[str]):
    token = _tenant_org_id.set(id)
    try:
        yield
    finally:
        _tenant_org_id.reset(token)

def set_tenant(id: Optional[str]):
    return _tenant_org_id.set(id)

def get_current_tenant() -> Optional[str]:
    return _tenant_org_id.get()

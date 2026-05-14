from contextvars import ContextVar
from contextlib import contextmanager
from typing import Optional

_tenant_slug: ContextVar[Optional[str]] = ContextVar("tenant_slug", default=None)

@contextmanager
def use_tenant(slug: Optional[str]):
    token = _tenant_slug.set(slug)
    try:
        yield
    finally:
        _tenant_slug.reset(token)

def set_tenant(slug: Optional[str]):
    return _tenant_slug.set(slug)

def get_current_tenant() -> Optional[str]:
    return _tenant_slug.get()

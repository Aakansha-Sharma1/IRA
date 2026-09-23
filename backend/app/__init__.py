import asyncio
import platform

# Windows asyncpg compatibility: use the Selector event loop policy
# because the Proactor loop can fail under pytest / FastAPI on Windows.
if platform.system() == "Windows":
    try:
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
    except AttributeError:
        pass

# IRA Backend Package

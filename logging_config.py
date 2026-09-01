import logging
import os
from pathlib import Path

def get_logger(job_name: str) -> logging.Logger:
    log_dir = Path(__file__).parent / "logs"
    log_dir.mkdir(exist_ok=True)

    logger = logging.getLogger(job_name)
    logger.setLevel(logging.DEBUG)

    # Évite les handlers dupliqués
    if logger.handlers:
        return logger

    handler = logging.FileHandler(
        log_dir / f"{job_name}.log",
        encoding="utf-8"
    )
    # Format compatible avec le grok Logstash
    handler.setFormatter(logging.Formatter(
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    ))
    logger.addHandler(handler)
    return logger
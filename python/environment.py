from env_var import env

FORMAT = "%(asctime)s %(name)s %(levelname)s: %(message)s"
SENTRY_URL = env("sentry").as_url().optional()

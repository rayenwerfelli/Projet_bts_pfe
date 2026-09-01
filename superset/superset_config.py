import os
SECRET_KEY = os.environ.get('SUPERSET_SECRET_KEY', 'dev-only-change-me')
HTML_SANITIZATION = False

FEATURE_FLAGS = {
    "DASHBOARD_RBAC": True,
}

from flask_appbuilder.security.manager import AUTH_OAUTH
from superset.security import SupersetSecurityManager

AUTH_TYPE = AUTH_OAUTH
AUTH_USER_REGISTRATION = True
AUTH_USER_REGISTRATION_ROLE = "Gamma"
AUTH_ROLES_SYNC_AT_LOGIN = True
AUTH_ROLES_MAPPING = {
    "DepCreditFinancement": ["DepCreditFinancement"],
    "Admin": ["Admin"],
    "Agence": ["Agence"],
    "DepRecouvrement": ["DepRecouvrement"],
    "DepTresorerie": ["DepTresorerie"],
    "DirectionExploitation": ["DirectionExploitation"],
    "DirecteurGeneral": ["DirecteurGeneral"],
}

OAUTH_PROVIDERS = [
    {
        "name": "keycloak",
        "token_key": "access_token",
        "icon": "fa-key",
        "remote_app": {
            "client_id": "superset",
                        "client_secret": os.environ.get('KEYCLOAK_CLIENT_SECRET', ''),
            "server_metadata_url":
                "http://localhost:8080/realms/superset/.well-known/openid-configuration",
            "client_kwargs": {
                "scope": "openid profile email"
            }
        }
    }
]


class KeycloakSecurityManager(SupersetSecurityManager):

    def oauth_user_info(self, provider, response=None):
        if provider == "keycloak":
            remote = self.appbuilder.sm.oauth_remotes[provider]
            userinfo_url = remote.load_server_metadata().get("userinfo_endpoint")
            me = remote.get(userinfo_url)
            data = me.json()
            import logging
            log = logging.getLogger(__name__)
            log.warning(f"KEYCLOAK USERINFO: {data}")
            groups = data.get("groups", [])
            role_keys = []
            if "/DepCreditFinancement" in groups:
                role_keys.append("DepCreditFinancement")
            if "/Agence" in groups:
                role_keys.append("Agence")
            if "/DepRecouvrement" in groups:
                role_keys.append("DepRecouvrement")
            if "/DepTresorerie" in groups:
                role_keys.append("DepTresorerie")
            if "/DirectionExploitation" in groups:
                role_keys.append("DirectionExploitation")
            if "/DirecteurGeneral" in groups:
                role_keys.append("DirecteurGeneral")
                role_keys.append("Admin")
            log.warning(f"GROUPS FOUND: {groups}")
            log.warning(f"ROLE KEYS MAPPED: {role_keys}")
            return {
                "username": data.get("preferred_username"),
                "first_name": data.get("given_name", ""),
                "last_name": data.get("family_name", ""),
                "email": data.get("email", ""),
                "role_keys": role_keys,
            }

    def auth_user_oauth(self, userinfo):
        user = super().auth_user_oauth(userinfo)
        import logging
        log = logging.getLogger(__name__)
        if user:
            log.warning(f"USER AFTER AUTH: {user.username}, ROLES: {[r.name for r in user.roles]}")
        else:
            log.warning("AUTH RETURNED NO USER")
        return user


CUSTOM_SECURITY_MANAGER = KeycloakSecurityManager
WTF_CSRF_ENABLED = False
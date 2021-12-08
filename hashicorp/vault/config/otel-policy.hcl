path "kv/data/otel/*" {
  capabilities = ["read", "update", "create"]
}

path "auth/approle/*" {
  capabilities = ["read", "update"]
}

path "auth/token/*" {
  capabilities = ["read", "update", "create"]
}
customization:
  systemExtensions:
    officialExtensions:
      - siderolabs/iscsi-tools
      - siderolabs/util-linux-tools
{{- if eq .Node.Host "localstorage-worker1" }}
      - siderolabs/i915
{{- end }}

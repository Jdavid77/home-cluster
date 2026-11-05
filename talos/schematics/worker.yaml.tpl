customization:
  systemExtensions:
    officialExtensions:
      - siderolabs/iscsi-tools
      - siderolabs/util-linux-tools
{{- if eq .Node.Host "localstorage-worker1" }}
      - siderolabs/i915
{{- end }}
{{- if eq .Node.Host "hp-worker3" }}
      - siderolabs/amdgpu
{{- end }}

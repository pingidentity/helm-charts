{{- define "pinglib.private-cert.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
apiVersion: v1
kind: Secret
metadata:
  {{ include "pinglib.metadata.labels" .  | nindent 2  }}
  {{ include "pinglib.metadata.annotations" .  | nindent 2  }}
  labels:
    alt-names: {{ include "pinglib.addreleasename" (append . $v.name) }}
  name: {{ include "pinglib.fullname" . }}-private-cert
  annotations:
    "helm.sh/hook": "pre-install"
    "helm.sh/hook-delete-policy": "before-hook-creation"
type: kubernetes.io/tls
data:
{{ ( include "pinglib.gen-cert" . ) | indent 2 }}
{{- end -}}


{{- define "pinglib.private-cert" -}}
  {{- include "pinglib.merge.templates" (append . "private-cert") -}}
{{- end -}}



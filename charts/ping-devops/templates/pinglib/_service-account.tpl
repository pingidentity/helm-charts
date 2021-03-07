{{- define "pinglib.service-account.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
apiVersion: v1
kind: ServiceAccount
metadata:
{{ include "pinglib.metadata.labels" . | indent 2  }}
  name: {{ include "pinglib.fullname" . }}
{{- end -}}


{{- define "pinglib.service-account" -}}
  {{- include "pinglib.merge.templates" (append . "service-account") -}}
{{- end -}}

{{- define "pinglib.configmap.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
apiVersion: v1
kind: ConfigMap
metadata: {{ include "pinglib.metadata.labels" .  | nindent 2  }}
  name: {{ include "pinglib.fullname" . }}-env-vars
data:
  {{- if $v.envs }}
    {{- toYaml $v.envs | nindent 2 }}
  {{- end }}
{{- end -}}


{{- define "pinglib.configmap" -}}
  {{- include "pinglib.merge.templates" (append . "configmap") -}}
{{- end -}}


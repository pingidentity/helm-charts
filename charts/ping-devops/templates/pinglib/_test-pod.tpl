{{- define "pinglib.test.pod.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
apiVersion: v1
kind: Pod
metadata: {{ include "pinglib.metadata.labels" .  | nindent 2 }}
  name: {{ include "pinglib.fullname" . }}-test
  annotations:
    "helm.sh/hook": test
spec:
  containers:
    - name: {{ include "pinglib.fullname" . }}-test
      image: {{ $v.externalImage.curl }}
{{- end -}}


{{- define "pinglib.test.pod" -}}
{{- include "pinglib.merge.templates" (append . "test.pod") -}}
{{- end -}}

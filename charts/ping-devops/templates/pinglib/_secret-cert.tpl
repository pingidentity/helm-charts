{{- define "pinglib.secret-cert.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
apiVersion: v1
kind: Secret
metadata: {{ include "pinglib.metadata.labels" .  | nindent 2  }}
  labels:
    alt-names: {{ include "pinglib.addreleasename" (append . $v.name) }}
  name: {{ include "pinglib.fullname" . }}-secret-cert
  annotations:
    "helm.sh/hook": "pre-install"
    "helm.sh/hook-delete-policy": "before-hook-creation"
type: kubernetes.io/tls
data:
{{ ( include "pinglib.gen-cert" . ) | indent 2 }}
{{- end -}}


{{- define "pinglib.secret-cert" -}}
  {{- include "pinglib.merge.templates" (append . "secret-cert") -}}
{{- end -}}

{{/* Generate certificates */}}
{{- define "pinglib.gen-cert" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $altNames := list (  "localhost" ) -}}
{{- $ca := genCA "pinglib-internal-ca" 365 -}}
{{- $cert := genSignedCert ( include "pinglib.addreleasename" (append . $v.name) ) (list "127.0.0.1") (list (  "localhost" )) 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}

{{- define "pinglib.ingress.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $fullName := include "pinglib.fullname" . -}}
{{- $defaultTlsSecret := $v.ingress.defaultTlsSecret -}}
{{- $defaultDomain := $v.ingress.defaultDomain -}}
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata: {{ include "pinglib.metadata.labels" .  | nindent 2  }}
  name: {{ include "pinglib.fullname" . }}
  annotations: {{ toYaml $v.ingress.annotations  | nindent 4 }}
spec:
  {{- if $v.ingress.tls }}
  tls:
  {{- range $v.ingress.tls }}
  - hosts:
    {{- range .hosts }}
    {{- if contains "._defaultDomain_" . }}
    {{- $rawHost := . | replace "._defaultDomain_" "" }}
    - {{ include "pinglib.ingress.gethostprepend" $ }}
      {{- $rawHost}}
      {{- include "pinglib.ingress.gethostappend" $ -}}
      {{- include "pinglib.ingress.gethostsubdomain" $ -}}
      .{{ $defaultDomain }}
    {{- else }}
    - {{ . | quote }}
    {{- end }}
    {{- end }}
    secretName: {{ .secretName | replace "_defaultTlsSecret_" (default "" $defaultTlsSecret) | quote }}
  {{- end }}
  {{- end }}
  rules:
  {{- range $v.ingress.hosts }}
    {{- if contains "._defaultDomain_" .host }}
    {{- $rawHost := .host | replace "._defaultDomain_" "" }}
    - host: {{ include "pinglib.ingress.gethostprepend" $ }}
      {{- $rawHost}}
      {{- include "pinglib.ingress.gethostappend" $ -}}
      {{- include "pinglib.ingress.gethostsubdomain" $ -}}
      .{{ $defaultDomain }}
    {{- else }}
    - host: {{ . | quote }}
    {{- end }}
      http:
        paths:
        {{- range .paths }}
          - path: {{ .path }}
            backend:
              serviceName: {{ $fullName }}
              servicePort: {{ .backend.servicePort }}
        {{- end }}
  {{- end }}
{{- end -}}


{{- define "pinglib.ingress" -}}
  {{- include "pinglib.merge.templates" (append . "ingress") -}}
{{- end -}}



{{- define "pinglib.ingress.gethostprepend" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
  {{- if eq $v.ingress.addReleaseNameToHost "prepend" }}
    {{- printf "%s-" $top.Release.Name -}}
  {{- end }}
{{- end -}}

{{- define "pinglib.ingress.gethostappend" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
  {{- if eq $v.ingress.addReleaseNameToHost "append" }}
    {{- printf "-%s" $top.Release.Name -}}
  {{- end }}
{{- end -}}

{{- define "pinglib.ingress.gethostsubdomain" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
  {{- if eq $v.ingress.addReleaseNameToHost "subdomain"}}
    {{- printf ".%s" $top.Release.Name -}}
  {{- end }}
{{- end -}}
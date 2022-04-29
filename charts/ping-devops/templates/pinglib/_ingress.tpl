{{- define "pinglib.ingress.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $fullName := include "pinglib.fullname" . -}}
{{- $defaultTlsSecret := $v.ingress.defaultTlsSecret -}}
{{- $defaultDomain := $v.ingress.defaultDomain -}}
{{- if semverCompare ">=1.19-0" $top.Capabilities.KubeVersion.Version }}
apiVersion: networking.k8s.io/v1
{{- else }}
apiVersion: networking.k8s.io/v1beta1
{{- end }}
kind: Ingress
metadata:
  {{ include "pinglib.metadata.labels" .  | nindent 2  }}
  {{ include "pinglib.metadata.annotations" .  | nindent 2  }}
  name: {{ include "pinglib.fullname" . }}
  annotations: {{ toYaml $v.ingress.annotations  | nindent 4 }}
spec:
  {{- if $v.ingress.tls }}
  tls:
  {{- range $v.ingress.tls }}
  - hosts:
    {{- range .hosts }}
    - {{ include "pinglib.ingress.hostname" (list $top $v .) | quote }}
    {{- end }}
    secretName: {{ .secretName | replace "_defaultTlsSecret_" (default "" $defaultTlsSecret) | quote }}
  {{- end }}
  {{- end }}
  rules:
  {{- range $v.ingress.hosts }}
    - host: {{ include "pinglib.ingress.hostname" (list $top $v .host) | quote  }}
      http:
        paths:
        {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
{{- if semverCompare ">=1.19-0" $top.Capabilities.KubeVersion.Version }}
              service:
                name: {{ $fullName }}
                port:
                  number: {{ (index $v.services .backend.serviceName).servicePort }}
{{- else }}
              serviceName: {{ $fullName }}
              servicePort: {{ (index $v.services .backend.serviceName).servicePort }}
{{- end }}
        {{- end }}
  {{- end }}
{{- end -}}


{{- define "pinglib.ingress" -}}
  {{- include "pinglib.merge.templates" (append . "ingress") -}}
{{- end -}}


{{/**********************************************************************
   ** pinglib.ingress.hostname
   **
   ** Returns an ingress hostname honoring the release-name and
   ** _defaultDomain_ flag.
   **********************************************************************/}}
{{- define "pinglib.ingress.hostname" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $rawHost := index . 2 -}}

{{- $fullName := include "pinglib.fullname" (list $top $v) -}}
{{- $defaultDomain := $v.ingress.defaultDomain -}}
{{- if contains "._defaultDomain_" $rawHost }}
  {{- $newHost := $rawHost | replace "._defaultDomain_" "" }}
  {{- include "pinglib.ingress.gethostprepend" $ -}}
  {{- $newHost -}}
  {{- include "pinglib.ingress.gethostappend" $ -}}
  {{- include "pinglib.ingress.gethostsubdomain" $ -}}
  .{{ $defaultDomain }}
{{- else }}
  {{- $rawHost }}
{{- end }}
{{- end }}


{{/**********************************************************************
   ** pinglib.ingress.gethostprepend
   **
   ** Prepends the release-name to the host if enabled
   **********************************************************************/}}
{{- define "pinglib.ingress.gethostprepend" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
  {{- if eq $v.ingress.addReleaseNameToHost "prepend" }}
    {{- printf "%s-" $top.Release.Name -}}
  {{- end }}
{{- end -}}

{{/**********************************************************************
   ** pinglib.ingress.gethostappend
   **
   ** Appends the release-name to the host if enabled
   **********************************************************************/}}
{{- define "pinglib.ingress.gethostappend" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
  {{- if eq $v.ingress.addReleaseNameToHost "append" }}
    {{- printf "-%s" $top.Release.Name -}}
  {{- end }}
{{- end -}}

{{/**********************************************************************
   ** pinglib.ingress.gethostsubdomain
   **
   ** Adds the release-name to the subdomain host if enabled
   **********************************************************************/}}
{{- define "pinglib.ingress.gethostsubdomain" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
  {{- if eq $v.ingress.addReleaseNameToHost "subdomain"}}
    {{- printf ".%s" $top.Release.Name -}}
  {{- end }}
{{- end -}}
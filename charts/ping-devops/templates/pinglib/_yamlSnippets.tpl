
{{/**********************************************************************
   ** metadata.labels snippet
   **********************************************************************/}}
{{- define "pinglib.metadata.labels" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
labels:
  {{- include "pinglib.selector.labels" . | nindent 2 }}
  helm.sh/chart: {{ include "pinglib.chart" . }}
  app.kubernetes.io/managed-by: {{ $top.Release.Service }}
  {{- if $v.labels }}
    {{- toYaml $v.labels | nindent 2 }}
  {{- end }}
{{- end -}}

{{/**********************************************************************
   ** selector.label snippet
   **********************************************************************/}}
{{- define "pinglib.selector.labels" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
app.kubernetes.io/name: {{ include "pinglib.name" . }}
app.kubernetes.io/instance: {{ $top.Release.Name }}
{{- end -}}

{{/**********************************************************************
   ** metadata.annotations snippet
   **********************************************************************/}}
{{- define "pinglib.metadata.annotations" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
  {{- if $v.annotations }}
annotations:
  {{- toYaml $v.annotations | nindent 2 }}
  {{- end }}
{{- end -}}

{{/**********************************************************************
   ** gen-cert - Generate certificates
   **********************************************************************/}}
{{- define "pinglib.gen-cert" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $subjectCN := include "pinglib.addreleasename" (append . $v.name) -}}
{{- $alt := dict "ips" (list) "names" (list $subjectCN ) -}}
{{- if $v.ingress.enabled }}
    {{- range $v.ingress.hosts }}
        {{- $noop := concat $alt.names (list (include "pinglib.ingress.hostname" (list $top $v .host))) | set $alt "names" }}
    {{- end }}
{{- end }}
{{- if $v.privateCert.additionalIPs }}
    {{- $noop := set $alt "ips" $v.privateCert.additionalIPs  }}
{{- end }}
{{- if $v.privateCert.additionalHosts }}
    {{- $noop := concat $alt.names $v.privateCert.additionalHosts | set $alt "names" }}
{{- end }}
{{- $cert := genSelfSignedCert $subjectCN $alt.ips $alt.names 365 -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}

{{/**********************************************************************
   ** gen-master-password - Generate Password
   **********************************************************************/}}
{{- define "pinglib.gen-master-password" -}}
  {{ with .Values.global.masterPassword }}
    {{- if .enabled }}
      {{- $strength := default "long" .strength }}
      {{- $name := default $.Release.Name .name }}
      {{- $site := default $.Chart.Name .site }}
      {{- $secret := default $.Release.Namespace .secret }}
      {{- derivePassword 1 $strength $secret $name $site }}
    {{- end }}
  {{- end }}
{{- end -}}
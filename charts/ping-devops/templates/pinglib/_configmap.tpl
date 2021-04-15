{{- define "pinglib.configmap.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
apiVersion: v1
kind: ConfigMap
metadata:
  {{ include "pinglib.metadata.labels" .  | nindent 2  }}
  name: {{ include "pinglib.fullname" . }}-env-vars
data:
  {{- if $v.envs }}
    {{- toYaml $v.envs | nindent 2 }}
  {{- end }}
{{- end -}}


{{- define "pinglib.configmap" -}}
  {{- include "pinglib.merge.templates" (append . "configmap") -}}
{{- end -}}


{{/**********************************************************************
   ** global.private.host.port
   **
   ** By default, all PRIVATE HOSTS/PORTS will be created even if the product isn't enabled.  This is done
   ** so we don't cause all workloads to restart just because a new product is added and a global-var
   ** configmap is generated.
   **********************************************************************/}}
{{- define "global.private.host.port" -}}
{{- $top := index . 0 }}
{{- $v := index . 1 }}
{{- $envPrefix := index . 2 }}
{{- $prodName := index . 3 }}
{{- with (index $top.Values $prodName) }}
  {{ $envPrefix }}_PRIVATE_HOSTNAME: {{ include "pinglib.addreleasename" (list $top $v .name) | quote }}
  {{- range $serviceName, $val := .services }}
    {{- if ne $serviceName "clusterExternalDNSHostname" }}
      {{- if $val.dataService }}
  {{ $envPrefix }}_PRIVATE_PORT_{{ $serviceName | replace "-" "_" | upper }}: {{ $val.servicePort | quote }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}

{{/**********************************************************************
   ** global.public.host.port
   **
   ** By default, all PUBLIC HOSTS/PORTS will be created even if the product isn't enabled.  This is done
   ** so we don't cause all workloads to restart just because a new product is added and a global-var
   ** configmap is generated.
   **********************************************************************/}}
{{- define "global.public.host.port" -}}
{{- $top := index . 0 }}
{{- $v := index . 1 }}
{{- $envPrefix := index . 2 }}
{{- $prodName := index . 3 }}
{{- with (index $top.Values $prodName) }}
  {{- if .ingress }}
    {{- if .ingress.enabled }}
      {{- $services := (index $top.Values $prodName).services }}
      {{- range .ingress.hosts }}
  {{ $envPrefix }}_PUBLIC_HOSTNAME: {{ include "pinglib.ingress.hostname" (list $top $v .host) | quote }}

        {{- range .paths }}
  {{ $envPrefix }}_PUBLIC_PORT_{{ .backend.serviceName | replace "-" "_" | upper }}: {{ (index $services .backend.serviceName).ingressPort | quote }}
        {{- end }}

      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}
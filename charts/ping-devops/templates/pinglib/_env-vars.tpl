{{- define "pinglib.env-vars.tpl" -}}
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


{{- define "pinglib.env-vars" -}}
  {{- include "pinglib.merge.templates" (append . "env-vars") -}}
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
    {{- if and (kindIs "map" $val) (not (include "pinglib.is_reserved_block_name" $serviceName)) }}
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
{{- $envPrefix := index . 2 }}
{{- $prodName := index . 3 }}
{{- $globalValues := deepCopy $top.Values.global -}}
{{- $prodValues := deepCopy (index $top.Values $prodName) -}}
{{- $mergedValues := mergeOverwrite $globalValues $prodValues -}}
{{- $services := $mergedValues.services -}}
{{- with $mergedValues }}
  {{- $gatewayHosts := default (list) .gateway.hosts -}}
  {{- if and .gateway.enabled (gt (len $gatewayHosts) 0) }}
    {{- range $gatewayHosts }}
  {{ $envPrefix }}_PUBLIC_HOSTNAME: {{ include "pinglib.gateway.hostname" (list $top $mergedValues .host) | quote }}

      {{- range .paths }}
  {{ $envPrefix }}_PUBLIC_PORT_{{ .backend.serviceName | replace "-" "_" | upper }}: {{ required (printf "Missing services.%s.gatewayPort for gateway route" .backend.serviceName) (index $services .backend.serviceName).gatewayPort | quote }}
      {{- end }}

    {{- end }}
  {{- else if .ingress.enabled }}
    {{- range .ingress.hosts }}
  {{ $envPrefix }}_PUBLIC_HOSTNAME: {{ include "pinglib.ingress.hostname" (list $top $mergedValues .host) | quote }}

      {{- range .paths }}
  {{ $envPrefix }}_PUBLIC_PORT_{{ .backend.serviceName | replace "-" "_" | upper }}: {{ (index $services .backend.serviceName).ingressPort | quote }}
      {{- end }}

    {{- end }}
  {{- else }}
    {{- range .ingress.hosts }}
  {{ $envPrefix }}_PUBLIC_HOSTNAME: localhost

      {{- range .paths }}
  {{ $envPrefix }}_PUBLIC_PORT_{{ .backend.serviceName | replace "-" "_" | upper }}: {{ (index $services .backend.serviceName).containerPort | quote }}
      {{- end }}

    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}

{{/**********************************************************************
   ** pinglib.env-vars.pingfederate
   **
   ** provide default pingfederate env configmap items (same for admin and engine)


  ingress:
    hosts:
      - host: pingfederate-admin._defaultDomain_
        paths:
        - path: /
          pathType: Prefix
          backend:
            serviceName: https

   **********************************************************************/}}
{{- define "pinglib.env-vars.pingfederate" -}}
{{- $top := index . 0 -}}
{{- $pingfedAdmin := mergeOverwrite (deepCopy $top.Values.global) (deepCopy (index $top.Values "pingfederate-admin")) -}}
{{- $httpsService := $pingfedAdmin.services.https -}}
{{- $gatewayHosts := default (list) $pingfedAdmin.gateway.hosts -}}
CLUSTER_BIND_ADDRESS: "NON_LOOPBACK"
CLUSTER_NAME: {{ $top.Release.Name | quote }}
DNS_QUERY_LOCATION: "{{ include "pinglib.fullclusterservicename" . }}.{{ $top.Release.Namespace }}.svc.cluster.local"
DNS_RECORD_TYPE: "A"
{{- if and $pingfedAdmin.gateway.enabled (gt (len $gatewayHosts) 0) }}
  {{- range $gatewayHosts }}
    {{- $gatewayHost := include "pinglib.gateway.hostname" (list $top $pingfedAdmin .host) -}}
    {{- $gatewayPort := required "Missing pingfederate-admin.services.https.gatewayPort for gateway mode" $httpsService.gatewayPort | int -}}
    {{- if eq $gatewayPort 443 }}
PF_ADMIN_PUBLIC_BASEURL: {{ printf "https://%s" $gatewayHost }}
    {{- else }}
PF_ADMIN_PUBLIC_BASEURL: {{ printf "https://%s:%d" $gatewayHost $gatewayPort }}
    {{- end }}
  {{- end }}
{{- else if $pingfedAdmin.ingress.enabled }}
  {{- range $pingfedAdmin.ingress.hosts }}
    {{- $ingressHost := include "pinglib.ingress.hostname" (list $top $pingfedAdmin .host) -}}
    {{- $ingressPort := $httpsService.ingressPort | int -}}
    {{- if eq $ingressPort 443 }}
PF_ADMIN_PUBLIC_BASEURL: {{ printf "https://%s" $ingressHost }}
    {{- else }}
PF_ADMIN_PUBLIC_BASEURL: {{ printf "https://%s:%d" $ingressHost $ingressPort }}
    {{- end }}
  {{- end }}
{{- else }}
  {{- $containerPort := $httpsService.containerPort | int -}}
  {{- if eq $containerPort 443 }}
PF_ADMIN_PUBLIC_BASEURL: "https://localhost"
  {{- else }}
PF_ADMIN_PUBLIC_BASEURL: {{ printf "https://localhost:%d" $containerPort }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "pinglib.gateway.httpRoutes" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $fullName := include "pinglib.fullname" . -}}
{{- $apiVersion := coalesce $v.gateway.httpRouteApiVersion $v.gateway.apiVersion "gateway.networking.k8s.io/v1" -}}
{{- $gatewayApiHasVersion := $top.Capabilities.APIVersions.Has $apiVersion -}}
{{- $gatewayApiHasKind := $top.Capabilities.APIVersions.Has (printf "%s/HTTPRoute" $apiVersion) -}}
{{- $gatewayApiSupported := or $gatewayApiHasVersion $gatewayApiHasKind -}}
{{- $routeHosts := default (list) $v.gateway.hosts -}}
{{- $routeHostCount := len $routeHosts -}}
{{- $metadataAnnotations := include "pinglib.gateway.metadataAnnotations" . | fromYaml -}}
{{- if and (gt $routeHostCount 0) (not $gatewayApiSupported) -}}
{{- fail (printf "Gateway API '%s' for HTTPRoute is not available in Capabilities.APIVersions. Install Gateway API CRDs or disable gateway routing." $apiVersion) -}}
{{- end -}}
{{- if gt $routeHostCount 0 -}}
{{- range $index, $routeHost := $routeHosts -}}
{{- $hostName := include "pinglib.gateway.hostname" (list $top $v $routeHost.host) -}}
{{- $routeName := $fullName -}}
{{- if gt $routeHostCount 1 -}}
{{- $routeName = printf "%s-%d" ($fullName | trunc 60 | trimSuffix "-") (add1 $index) -}}
{{- end -}}
{{- if gt $index 0 }}
---
{{- end }}
apiVersion: {{ $apiVersion }}
kind: HTTPRoute
metadata:
  {{ include "pinglib.metadata.labels" (list $top $v)  | nindent 2  }}
  name: {{ $routeName }}
  {{- if $metadataAnnotations }}
  annotations: {{ toYaml $metadataAnnotations | nindent 4 }}
  {{- end }}
spec:
  {{- if $v.gateway.parentRefs }}
  parentRefs:
  {{- toYaml $v.gateway.parentRefs | nindent 2 }}
  {{- end }}
  hostnames:
  - {{ $hostName | quote }}
  rules:
    {{- range $routeHost.paths }}
{{- $serviceName := required "gateway.hosts[].paths[].backend.serviceName is required" .backend.serviceName -}}
{{- $serviceConfig := index $v.services $serviceName -}}
{{- if not $serviceConfig -}}
      {{- fail (printf "gateway.hosts[].paths[].backend.serviceName '%s' does not exist under services" $serviceName) -}}
{{- end }}
{{- $servicePort := required (printf "Missing services.%s.servicePort for gateway route backend" $serviceName) $serviceConfig.servicePort }}
  - matches:
    - path:
        type: {{ include "pinglib.gateway.pathMatchType" .pathType }}
        value: {{ .path | quote }}
    backendRefs:
    - name: {{ $fullName }}
      port: {{ $servicePort }}
    {{- end }}
{{- end }}
{{- end -}}
{{- end -}}


{{- define "pinglib.gateway.tcpRoutes" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $fullName := include "pinglib.fullname" . -}}
{{- $apiVersion := default "gateway.networking.k8s.io/v1alpha2" $v.gateway.tcpRouteApiVersion -}}
{{- $gatewayApiHasVersion := $top.Capabilities.APIVersions.Has $apiVersion -}}
{{- $gatewayApiHasKind := $top.Capabilities.APIVersions.Has (printf "%s/TCPRoute" $apiVersion) -}}
{{- $gatewayApiSupported := or $gatewayApiHasVersion $gatewayApiHasKind -}}
{{- $tcpRoutes := default (list) $v.gateway.tcpRoutes -}}
{{- $metadataAnnotations := include "pinglib.gateway.metadataAnnotations" . | fromYaml -}}
{{- if and (gt (len $tcpRoutes) 0) (not $gatewayApiSupported) -}}
{{- fail (printf "Gateway API '%s' for TCPRoute is not available in Capabilities.APIVersions. Install Gateway API experimental CRDs or disable gateway tcpRoutes." $apiVersion) -}}
{{- end -}}
{{- if and (gt (len $tcpRoutes) 0) (eq (len (default (list) $v.gateway.parentRefs)) 0) -}}
{{- fail "gateway.parentRefs must not be empty when gateway.tcpRoutes are configured" -}}
{{- end -}}
{{- range $index, $tcpRoute := $tcpRoutes -}}
{{- $routeName := required "gateway.tcpRoutes[].name is required" $tcpRoute.name -}}
{{- $sectionName := required (printf "gateway.tcpRoutes[%d].sectionName is required" $index) $tcpRoute.sectionName -}}
{{- $backend := required (printf "gateway.tcpRoutes[%d].backend is required" $index) $tcpRoute.backend -}}
{{- $serviceName := required (printf "gateway.tcpRoutes[%d].backend.serviceName is required" $index) $backend.serviceName -}}
{{- $serviceConfig := index $v.services $serviceName -}}
{{- if not $serviceConfig -}}
{{- fail (printf "gateway.tcpRoutes[%d].backend.serviceName '%s' does not exist under services" $index $serviceName) -}}
{{- end -}}
{{- $servicePort := required (printf "Missing services.%s.servicePort for gateway route backend" $serviceName) $serviceConfig.servicePort }}
{{- $parentRefs := deepCopy $v.gateway.parentRefs -}}
{{- range $parentRef := $parentRefs -}}
{{- $_ := set $parentRef "sectionName" $sectionName -}}
{{- end -}}
{{- if gt $index 0 }}
---
{{- end }}
apiVersion: {{ $apiVersion }}
kind: TCPRoute
metadata:
  {{ include "pinglib.metadata.labels" (list $top $v)  | nindent 2  }}
  name: {{ printf "%s-%s" ($fullName | trunc 52 | trimSuffix "-") $routeName }}
  {{- if $metadataAnnotations }}
  annotations: {{ toYaml $metadataAnnotations | nindent 4 }}
  {{- end }}
spec:
  parentRefs:
  {{- toYaml $parentRefs | nindent 2 }}
  rules:
  - backendRefs:
    - name: {{ $fullName }}
      port: {{ $servicePort }}
{{- end -}}
{{- end -}}


{{- define "pinglib.gateway.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- include "pinglib.gateway.httpRoutes" (list $top $v) -}}
{{- if and (gt (len (default (list) $v.gateway.hosts)) 0) (gt (len (default (list) $v.gateway.tcpRoutes)) 0) }}
---
{{- end }}
{{- include "pinglib.gateway.tcpRoutes" (list $top $v) -}}
{{- end -}}


{{- define "pinglib.gateway" -}}
{{- $top := index . 0 -}}
{{- $prodName := index . 1 -}}
{{- $globalValues := deepCopy $top.Values.global -}}
{{- $prodValues := deepCopy (index $top.Values $prodName) -}}
{{- $mergedValues := mergeOverwrite $globalValues $prodValues -}}
{{- include "pinglib.gateway.tpl" (list $top $mergedValues) -}}
{{- end -}}


{{- define "pinglib.gateway.pathMatchType" -}}
{{- required "gateway.hosts[].paths[].pathType is required and must be one of: Exact, PathPrefix, RegularExpression" . -}}
{{- end -}}


{{- define "pinglib.gateway.metadataAnnotations" -}}
{{- $v := index . 1 -}}
{{- $metadataAnnotations := dict -}}
{{- if $v.annotations -}}
  {{- $metadataAnnotations = mergeOverwrite (deepCopy $metadataAnnotations) $v.annotations -}}
{{- end -}}
{{- if $v.gateway.annotations -}}
  {{- $metadataAnnotations = mergeOverwrite (deepCopy $metadataAnnotations) $v.gateway.annotations -}}
{{- end -}}
{{- toYaml $metadataAnnotations -}}
{{- end -}}

{{/**********************************************************************
   ** pinglib.gateway.hostname
   **
   ** Returns a gateway hostname honoring the gateway-specific release-name
   ** and _defaultDomain_ flags.
   **********************************************************************/}}
{{- define "pinglib.gateway.hostname" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $rawHost := index . 2 -}}

{{- $defaultDomain := default "example.com" $v.gateway.defaultDomain -}}
{{- if contains "._defaultDomain_" $rawHost }}
  {{- $newHost := $rawHost | replace "._defaultDomain_" "" }}
  {{- include "pinglib.gateway.gethostprepend" (list $top $v) -}}
  {{- $newHost -}}
  {{- include "pinglib.gateway.gethostappend" (list $top $v) -}}
  {{- include "pinglib.gateway.gethostsubdomain" (list $top $v) -}}
  .{{ $defaultDomain }}
{{- else }}
  {{- $rawHost }}
{{- end }}
{{- end }}

{{/**********************************************************************
   ** pinglib.gateway.gethostprepend
   **
   ** Prepends the release-name to the host if enabled
   **********************************************************************/}}
{{- define "pinglib.gateway.gethostprepend" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
  {{- if eq (default "subdomain" $v.gateway.addReleaseNameToHost) "prepend" }}
    {{- printf "%s-" $top.Release.Name -}}
  {{- end }}
{{- end -}}

{{/**********************************************************************
   ** pinglib.gateway.gethostappend
   **
   ** Appends the release-name to the host if enabled
   **********************************************************************/}}
{{- define "pinglib.gateway.gethostappend" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
  {{- if eq (default "subdomain" $v.gateway.addReleaseNameToHost) "append" }}
    {{- printf "-%s" $top.Release.Name -}}
  {{- end }}
{{- end -}}

{{/**********************************************************************
   ** pinglib.gateway.gethostsubdomain
   **
   ** Adds the release-name to the subdomain host if enabled
   **********************************************************************/}}
{{- define "pinglib.gateway.gethostsubdomain" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
  {{- if eq (default "subdomain" $v.gateway.addReleaseNameToHost) "subdomain" }}
    {{- printf ".%s" $top.Release.Name -}}
  {{- end }}
{{- end -}}

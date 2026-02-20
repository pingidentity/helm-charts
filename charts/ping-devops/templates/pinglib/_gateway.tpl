{{- define "pinglib.gateway.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $fullName := include "pinglib.fullname" . -}}
{{- $apiVersion := default "gateway.networking.k8s.io/v1" $v.gateway.apiVersion -}}
{{- $gatewayApiHasVersion := $top.Capabilities.APIVersions.Has $apiVersion -}}
{{- $gatewayApiHasKind := $top.Capabilities.APIVersions.Has (printf "%s/HTTPRoute" $apiVersion) -}}
{{- $gatewayApiSupported := or $gatewayApiHasVersion $gatewayApiHasKind -}}
{{- $routeHosts := default (list) $v.gateway.hosts -}}
{{- $routeHostCount := len $routeHosts -}}
{{- $metadataAnnotations := dict -}}
{{- if $v.annotations -}}
  {{- $metadataAnnotations = mergeOverwrite (deepCopy $metadataAnnotations) $v.annotations -}}
{{- end -}}
{{- if $v.gateway.annotations -}}
  {{- $metadataAnnotations = mergeOverwrite (deepCopy $metadataAnnotations) $v.gateway.annotations -}}
{{- end -}}
{{- if and (gt $routeHostCount 0) (not $gatewayApiSupported) -}}
{{- fail (printf "Gateway API '%s' for HTTPRoute is not available in Capabilities.APIVersions. Install Gateway API CRDs or disable gateway routing." $apiVersion) -}}
{{- end -}}
{{- if gt (len $routeHosts) 0 -}}
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
  - matches:
    - path:
        type: {{ include "pinglib.gateway.pathMatchType" .pathType }}
        value: {{ .path | quote }}
    backendRefs:
    - name: {{ $fullName }}
      port: {{ (index $v.services .backend.serviceName).servicePort }}
    {{- end }}
{{- end }}
{{- end -}}
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

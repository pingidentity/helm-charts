{{- define "pinglib.service.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
apiVersion: v1
kind: Service
metadata:
  {{ include "pinglib.metadata.labels" .  | nindent 2  }}
    {{- if $v.services.labels }}
    {{ toYaml $v.services.labels | nindent 4}}
    {{- end }}
  annotations:
    {{- if $v.annotations }}
    {{ toYaml $v.annotations | nindent 4 }}
    {{- end }}
    {{- if $v.services.annotations }}
    {{ toYaml $v.services.annotations | nindent 4 }}
    {{- end }}
    {{- if $v.services.dataExternalDNSHostname }}
    external-dns.alpha.kubernetes.io/hostname: {{ $v.services.dataExternalDNSHostname }}
    {{- end }}
  name: {{ include "pinglib.fullname" . }}
spec:
  {{- if $v.services.useLoadBalancerForDataService }}
  type: LoadBalancer
  {{- end }}
  ports:
  {{- range $serviceName, $val := $v.services }}
  {{- if kindIs "map" $val }}
  {{- if $val.dataService }}
    - name: {{ $serviceName }}
      port: {{ $val.servicePort }}
      targetPort: {{ default $val.servicePort $val.containerPort }}
      protocol: {{ default "TCP" $val.protocol }}
  {{- end }}
  {{- end }}
  {{- end }}
  selector:
    {{ include "pinglib.selector.labels" . | nindent 4 }}
{{- end -}}


{{- define "pinglib.service" -}}
  {{- include "pinglib.merge.templates" (append . "service") -}}
{{- end -}}

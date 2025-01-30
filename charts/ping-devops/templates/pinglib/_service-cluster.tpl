{{- define "pinglib.service-cluster.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
apiVersion: v1
kind: Service
metadata:
  {{ include "pinglib.metadata.labels" .  | nindent 2  }}
    {{- if $v.services.clusterServiceLabels }}
    {{ toYaml $v.services.clusterServiceLabels | nindent 4}}
    {{- end }}
  annotations:
    {{- if $v.annotations }}
    {{ toYaml $v.annotations | nindent 4 }}
    {{- end }}
    {{- if $v.services.clusterServiceAnnotations }}
    {{ toYaml $v.services.clusterServiceAnnotations | nindent 4 }}
    {{- end }}
    {{- if $v.services.clusterExternalDNSHostname }}
    external-dns.alpha.kubernetes.io/hostname: {{ $v.services.clusterExternalDNSHostname }}
    {{- end }}
  name: {{ include "pinglib.fullclusterservicename" . }}
spec:
  type: ClusterIP
  clusterIP: None
  ports:
  {{- range $serviceName, $val := $v.services }}
  {{- if and (kindIs "map" $val) (not (include "pinglib.is_reserved_block_name" $serviceName)) }}
  {{- if $val.clusterService }}
    - name: {{ $serviceName }}
      port: {{ required "containerPort is required for services with clusterService:true" $val.containerPort }}
      # targetPort isn't provided as it will ALWAYS be the same as the
      # port of the service,since it's a type:ClusterIP or headless
      # service
      protocol: {{ default "TCP" $val.protocol }}
  {{- end }}
  {{- end }}
  {{- end }}
{{- end -}}


{{- define "pinglib.service-cluster" -}}
  {{- include "pinglib.merge.templates" (append . "service-cluster") -}}
{{- end -}}

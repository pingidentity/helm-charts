{{- define "pinglib.service-cluster.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
apiVersion: v1
kind: Service
metadata:
  {{ include "pinglib.metadata.labels" .  | nindent 2  }}
  {{ include "pinglib.metadata.annotations" .  | nindent 2  }}
{{- if $v.services.clusterExternalDNSHostname }}
  annotations:
    external-dns.alpha.kubernetes.io/hostname: {{ $v.services.clusterExternalDNSHostname }}
{{- end }}
  name: {{ include "pinglib.fullclusterservicename" . }}
spec:
  type: ClusterIP
  clusterIP: None
  ports:
  {{- range $serviceName, $val := $v.services }}
  {{- if kindIs "map" $val }}
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

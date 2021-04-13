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
  name: {{ include "pinglib.fullname" . }}-cluster
spec:
  type: ClusterIP
  clusterIP: None
  ports:
  {{- range $serviceName, $val := $v.services }}
  {{- if ne $serviceName "clusterExternalDNSHostname" }}
  {{- if $val.clusterService }}
    - name: {{ $serviceName }}
      port: {{ $val.servicePort }}
      targetPort: {{ default $val.servicePort $val.containerPort }}
      protocol: {{ default "TCP" $val.protocol }}
  {{- end }}
  {{- end }}
  {{- end }}
{{- end -}}


{{- define "pinglib.service-cluster" -}}
  {{- include "pinglib.merge.templates" (append . "service-cluster") -}}
{{- end -}}

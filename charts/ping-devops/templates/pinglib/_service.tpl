{{- define "pinglib.service.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
apiVersion: v1
kind: Service
metadata:
  {{ include "pinglib.metadata.labels" .  | nindent 2  }}
  {{ include "pinglib.metadata.annotations" .  | nindent 2  }}
{{- if $v.services.dataExternalDNSHostname }}
  annotations:
    external-dns.alpha.kubernetes.io/hostname: {{ $v.services.dataExternalDNSHostname }}
{{- end }}
  name: {{ include "pinglib.fullname" . }}
spec:
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

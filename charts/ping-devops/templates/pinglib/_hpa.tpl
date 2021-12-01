{{- define "pinglib.hpa.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  {{ include "pinglib.metadata.labels" . | nindent 2  }}
  {{ include "pinglib.metadata.annotations" .  | nindent 2  }}
  name: {{ include "pinglib.fullname" . }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "pinglib.fullname" . }}
  minReplicas: {{ $v.clustering.autoscaling.minReplicas }}
  maxReplicas: {{ $v.clustering.autoscaling.maxReplicas }}
  metrics:
  {{- with $v.clustering.autoscaling.targetCPUUtilizationPercentage }}
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {{ . }}
  {{- end }}
  {{- with $v.clustering.autoscaling.targetMemoryUtilizationPercentage }}
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: {{ . }}
  {{- end }}
  behavior:
  {{- with $v.clustering.autoscaling.behavior }}
{{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $v.clustering.autoscalingMetricsTemplate }}
{{- toYaml . | nindent 2 }}
  {{- end }}
{{- end -}}


{{- define "pinglib.hpa" -}}
  {{- include "pinglib.merge.templates" (append . "hpa") -}}
{{- end -}}

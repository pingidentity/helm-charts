{{- define "pinglib.hpa.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- if $top.Capabilities.APIVersions.Has "autoscaling/v2" }}
apiVersion: autoscaling/v2
{{- else }}
apiVersion: autoscaling/v2beta2
{{- end }}
kind: HorizontalPodAutoscaler
metadata:
  {{ include "pinglib.metadata.labels" . | nindent 2  }}
  {{- if $v.clustering.autoscaling.labels }}
    {{ toYaml $v.clustering.autoscaling.labels | nindent 4 }}
  {{- end }}
  annotations:
  {{- if $v.annotations }}
    {{ toYaml $v.annotations | nindent 4 }}
  {{- end }}
  {{- if $v.clustering.autoscaling.annotations }}
    {{ toYaml $v.clustering.autoscaling.annotations | nindent 4 }}
  {{- end }}
  name: {{ include "pinglib.fullname" . }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: {{ $v.workload.type }}
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
    {{- with $v.clustering.autoscalingMetricsTemplate }}
  {{- toYaml . | nindent 2 }}
    {{- end }}
  behavior:
  {{- with $v.clustering.autoscaling.behavior }}
{{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}


{{- define "pinglib.hpa" -}}
  {{- include "pinglib.merge.templates" (append . "hpa") -}}
{{- end -}}

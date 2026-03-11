{{- define "pinglib.podDisruptionBudget.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $pdb := $v.workload.podDisruptionBudget -}}
{{- if $pdb.enabled }}
{{- $selectorLabels := (include "pinglib.selector.labels" . | fromYaml) -}}
{{- if empty $selectorLabels }}
{{- fail (printf "workload.podDisruptionBudget for %s requires a non-empty selector" $v.name) }}
{{- end }}
{{- $hasMinAvailable := ne $pdb.minAvailable nil -}}
{{- $hasMaxUnavailable := ne $pdb.maxUnavailable nil -}}
{{- if and $hasMinAvailable $hasMaxUnavailable }}
{{- fail (printf "workload.podDisruptionBudget for %s must set only one of minAvailable or maxUnavailable" $v.name) }}
{{- end }}
{{- if not (or $hasMinAvailable $hasMaxUnavailable) }}
{{- fail (printf "workload.podDisruptionBudget for %s must set either minAvailable or maxUnavailable when enabled" $v.name) }}
{{- end }}
{{- if and (ne $pdb.unhealthyPodEvictionPolicy nil) (not (semverCompare ">=1.31-0" $top.Capabilities.KubeVersion.Version)) }}
{{- fail (printf "workload.podDisruptionBudget.unhealthyPodEvictionPolicy for %s requires Kubernetes v1.31+" $v.name) }}
{{- end }}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  {{ include "pinglib.metadata.labels" . | nindent 2  }}
  {{- if $pdb.labels }}
    {{ toYaml $pdb.labels | nindent 4 }}
  {{- end }}
  annotations:
  {{- if $v.annotations }}
    {{ toYaml $v.annotations | nindent 4 }}
  {{- end }}
  {{- if $pdb.annotations }}
    {{ toYaml $pdb.annotations | nindent 4 }}
  {{- end }}
  name: {{ include "pinglib.fullname" . }}
spec:
  selector:
    matchLabels:
      {{- include "pinglib.selector.labels" . | nindent 6 }}
  {{- if $hasMinAvailable }}
  minAvailable: {{ toYaml $pdb.minAvailable | trim }}
  {{- end }}
  {{- if $hasMaxUnavailable }}
  maxUnavailable: {{ toYaml $pdb.maxUnavailable | trim }}
  {{- end }}
  {{- if ne $pdb.unhealthyPodEvictionPolicy nil }}
  unhealthyPodEvictionPolicy: {{ $pdb.unhealthyPodEvictionPolicy }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "pinglib.podDisruptionBudget" -}}
{{- include "pinglib.merge.templates" (append . "podDisruptionBudget") -}}
{{- end -}}

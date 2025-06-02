{{- define "pinglib.cronjob.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 }}
{{- if $v.cronjob.enabled -}}
{{- $jobName := include "pinglib.fullname" (list $top $v) | printf "%s-cronjob" -}}
{{- $podSelector := printf "app.kubernetes.io/name=%s,app.kubernetes.io/instance=%s" $v.name $top.Release.Name -}}
{{- $workloadType := default "Deployment" ($v.workload.type | default "Deployment") -}}
{{- $shellCmd := "" -}}
{{- if eq $workloadType "StatefulSet" -}}
  {{- $podName := print $top.Release.Name "-" $v.name "-0" -}}
  {{- $shellCmd = printf "kubectl exec -ti %s --container utility-sidecar -- %s" $podName (join " " $v.cronjob.args) -}}
{{- else -}}
  {{- $shellCmd = printf "kubectl exec -ti $(kubectl get pod -l %s -o jsonpath='{.items[0].metadata.name}') --container utility-sidecar -- %s" $podSelector (join " " $v.cronjob.args) -}}
{{- end -}}
{{- $args := list "-c" $shellCmd -}}

{{- if $top.Capabilities.APIVersions.Has "batch/v1" }}
apiVersion: batch/v1
{{- else }}
apiVersion: batch/v1beta1
{{- end }}
kind: CronJob
metadata:
  {{ include "pinglib.metadata.labels" . | nindent 2 }}
  {{ include "pinglib.metadata.annotations" . | nindent 2 }}
  name: {{ $jobName }}
spec:
  {{ if $v.cronjob.spec }}
  {{ toYaml $v.cronjob.spec | nindent 2 }}
  {{ end }}
  {{ if not $v.cronjob.spec.jobTemplate }}
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccount: {{ include "pinglib.fullname" . }}-internal-kubectl
          restartPolicy: OnFailure
          {{- if $v.cronjob.podSecurityContext }}
          securityContext: {{ toYaml $v.cronjob.podSecurityContext | nindent 12 }}
          {{- end }}
          containers:
          - name: {{ $jobName }}
            image: {{ $v.cronjob.image }}
            {{- if $v.cronjob.containerSecurityContext }}
            securityContext: {{ toYaml $v.cronjob.containerSecurityContext | nindent 14 }}
            {{- end }}
            command: ["sh"]
            args:
              {{- range $args }}
              - {{ . | quote }}
              {{- end }}
{{- end }}
{{- end -}}
{{- end -}}

{{- define "pinglib.cronjob" -}}
  {{- include "pinglib.merge.templates" (append . "cronjob") -}}
{{- end -}}

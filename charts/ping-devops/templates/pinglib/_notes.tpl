{{/**********************************************************************
** Ping DevOps Notes Header
**********************************************************************/}}
{{- define "pinglib.notes.header" -}}
#-------------------------------------------------------------------------------------
# Ping DevOps
#
# Description: {{ .Chart.Description }}
#-------------------------------------------------------------------------------------
{{- end -}}


{{/**********************************************************************
** Ping DevOps Notes Footer
**********************************************************************/}}
{{- define "pinglib.notes.footer" -}}
#-------------------------------------------------------------------------------------
{{- if .Values.help }}
    {{- if      eq "all" .Values.help.values }}{{ toYaml . }}
    {{- else if eq "global" .Values.help.values }}{{ .Values.help.values }}:{{ toYaml .Values.global | nindent 2 }}
    {{- else }}{{ .Values.help.values }}:{{ toYaml (merge (index .Values .Values.help.values) .Values.global) | nindent 2 }}
    {{- end }}
#-------------------------------------------------------------------------------------
{{- end }}
# To see values info, simply set one of the following on your helm install/upgrade
#
#    --set help.values=all         # Provides all (i.e. .Values, .Release, .Chart, ...) yaml
#    --set help.values=global      # Provides global values
#    --set help.values={ image }   # Provides image values merged with global
#-------------------------------------------------------------------------------------
{{- end -}}
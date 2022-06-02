{{/**********************************************************************
   ** Expand the name of the chart.
   **********************************************************************/}}
{{- define "pinglib.name" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- default "global" $v.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/**********************************************************************
   ** Create a default fully qualified app name.
   ** We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
   ** If release name contains chart name it will be used as a full name.
   **********************************************************************/}}
{{- define "pinglib.fullname" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
    {{- include "pinglib.addreleasename" (append . (default "global" $v.name)) -}}
{{- end -}}

{{/**********************************************************************
   ** Create a default fully qualified image name.
   ** We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
   ** If release name contains image name it will be used as a full name.
   **********************************************************************/}}
{{- define "pinglib.fullimagename" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
    {{- include "pinglib.addreleasename" (append . $v.image.name) -}}
{{- end -}}

{{/**********************************************************************
   ** Create a cluster service name. Used with StatefulSets
   **********************************************************************/}}
{{- define "pinglib.fullclusterservicename" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
    {{- include "pinglib.addreleasename" (append . (default (printf "%s-cluster" $v.name) $v.services.clusterServiceName)) -}}
{{- end -}}

{{/**********************************************************************
   ** Create chart name and version as used by the chart label.
   **********************************************************************/}}
{{- define "pinglib.chart" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- printf "%s-%s" $top.Chart.Name $top.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/**********************************************************************
   ** Add Release Name
   **********************************************************************/}}
{{- define "pinglib.addreleasename" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $name := index . 2 -}}
{{- if eq $v.addReleaseNameToResource "prepend" -}}
    {{- printf "%s-%s" $top.Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- else if eq $v.addReleaseNameToResource "append" -}}
    {{- printf "%s-%s" $name $top.Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{- printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/**********************************************************************
   ** Fail template rendering and dump variable value for debugging.
   **********************************************************************/}}
{{- define "pinglib.var_dump" -}}
{{- . | mustToPrettyJson | printf "\nJSON dumped variable: \n%s" | fail }}
{{- end -}}

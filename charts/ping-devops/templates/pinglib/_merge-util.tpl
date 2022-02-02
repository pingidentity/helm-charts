{{- /*
mylibchart.merge-templates will merge two YAML templates and output the result.
This takes an array of three values:
- the top context                                        .
- the product name                                       pingdirectory
- the resource type                                      deployment

These will create
- the template name of the overrides (destination)       pingdirectory.deployment
- the template name of the base (source)                 pinglib.deployment.tpl
*/ -}}
{{- define "pinglib.merge.templates" -}}
    {{- $top := index . 0 -}}
    {{- $prodName := index . 1 -}}
    {{- $resourceType := index . 2 -}}

    {{- $globalValues := deepCopy $top.Values.global -}}
    {{- $prodValues := deepCopy (index $top.Values $prodName) -}}
    {{- $mergedValues := mergeOverwrite $globalValues $prodValues -}}
    {{- if or $mergedValues.enabled (eq $prodName "global") -}}
        {{- $paramList := list $top $mergedValues -}}

        {{- $overrideTemplate := printf "%s.%s" $prodName $resourceType -}}
        {{- $baseTemplate := printf "pinglib.%s.tpl" $resourceType -}}
        {{- $overrides := fromYaml (include $overrideTemplate $paramList) | default (dict ) -}}
        {{- $tpl := fromYaml (include $baseTemplate $paramList) | default (dict ) -}}
        {{- $final := merge $tpl $overrides -}}
        {{- if $final -}}
            {{- toYaml $final -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

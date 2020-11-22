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

    {{- $mergedValues := merge (index $top.Values $prodName) $top.Values.global -}}
    {{- if or $mergedValues.enabled (eq $prodName "global") -}}
        {{- $paramList := list $top $mergedValues -}}

        {{- $overrideTemplate := printf "%s.%s" $prodName $resourceType -}}
        {{- $baseTemplate := printf "pinglib.%s.tpl" $resourceType -}}
        {{- $overrides := fromYaml (include $overrideTemplate $paramList) | default (dict ) -}}
        {{- $tpl := fromYaml (include $baseTemplate $paramList) | default (dict ) -}}
        {{- toYaml (merge $tpl $overrides) -}}
    {{- end -}}
{{- end -}}

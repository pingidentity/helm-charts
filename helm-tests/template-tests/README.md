# Helm template tests
In this directory you can add YAML files used to test the template YAML generated by Helm. YAML files in this directory will be automatically tested in the Gitlab pipeline with the [ci_scripts/test_helm_template.py](../../ci_scripts/test_helm_template.py) script. Tests are run with the `helm template` command; nothing is actually deployed to the cluster. These types of tests are good for verifying logic added to .tpl files in the chart.

To run the tests locally, run `ci_scripts/test_helm_template.py test --test-file helm-tests/template-tests/testfile.yaml`. See `ci_scripts/test_helm_template.py help` for more information on running the script.

See the [sample.yaml](sample.yaml) file in this directory for the expected file structure to use when writing tests.
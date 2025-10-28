#!/bin/bash
# Checkout our version of every renamed file
git checkout ubi2 -- tests/tosca_2_0/examples/types/examples-mytypes.yaml
git checkout ubi2 -- tests/tosca_2_0/examples/types/examples-mytypes_test.py
git checkout ubi2 -- tests/tosca_2_0/full-mesh/full-mesh-types.yaml
git checkout ubi2 -- tests/tosca_2_0/full-mesh/full-mesh-types_test.py
git checkout ubi2 -- tests/tosca_2_0/many-to-many-relationships/many-to-many-relationships-types.yaml
git checkout ubi2 -- tests/tosca_2_0/many-to-many-relationships/many-to-many-relationships-types_test.py
git checkout ubi2 -- tests/tosca_2_0/mapping-a-requirement-multiple-times/mapping-a-requirement-multiple-times-types.yaml
git checkout ubi2 -- tests/tosca_2_0/mapping-a-requirement-multiple-times/mapping-a-requirement-multiple-times-types_test.py
git checkout ubi2 -- tests/tosca_2_0/mapping-multiple-requirements-with-the-same-name/mapping-multiple-requirements-with-the-same-name-types.yaml
git checkout ubi2 -- tests/tosca_2_0/mapping-multiple-requirements-with-the-same-name/mapping-multiple-requirements-with-the-same-name-types_test.py
git checkout ubi2 -- tests/tosca_2_0/matched-pairs/matched-pairs-types.yaml
git checkout ubi2 -- tests/tosca_2_0/matched-pairs/matched-pairs-types_test.py
git checkout ubi2 -- tests/tosca_2_0/one-to-many-relationships/one-to-many-relationships-types.yaml
git checkout ubi2 -- tests/tosca_2_0/one-to-many-relationships/one-to-many-relationships-types_test.py
git checkout ubi2 -- tests/tosca_2_0/random-pairs/random-pairs-types.yaml
git checkout ubi2 -- tests/tosca_2_0/random-pairs/random-pairs-types_test.py
git checkout ubi2 -- tests/tosca_2_0/requirement-count/requirement-count-types.yaml
git checkout ubi2 -- tests/tosca_2_0/requirement-count/requirement-count-types_test.py
git checkout ubi2 -- tests/tosca_2_0/requirement-mapping-and-selectable-nodes/requirement-mapping-and-selectable-nodes-types.yaml
git checkout ubi2 -- tests/tosca_2_0/requirement-mapping-and-selectable-nodes/requirement-mapping-and-selectable-nodes-types_test.py
git checkout ubi2 -- tests/tosca_2_0/requirement-mapping-rules/requirement-mapping-rules-types.yaml
git checkout ubi2 -- tests/tosca_2_0/requirement-mapping-rules/requirement-mapping-rules-types_test.py

# Add all changes
git add .

# Commit the merge
git commit -m "Merge master into ubi2, keeping ubi2 file names"

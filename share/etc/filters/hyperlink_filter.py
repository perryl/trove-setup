# Copyright (C) 2015 Codethink Limited
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program.  If not, see <http://www.gnu.org/licenses/>.


import os
import re
import subprocess
import yaml

from collections import OrderedDict
from shutil import move


class Error(Exception):
    pass


class InvalidFormatError(Error):

    def __init__(self, morph_file):
        self.morph_file = morph_file
        Error.__init__(self, 'Morphology is not a dict: %s' % self.morph_file)


class YamlLoadError(Error):

    def __init__(self, morph_file):
        self.morph_file = morph_file
        Error.__init__(self, 'Could not load file: %' % self.morph_file)


class VersionNotFound(Error):

    def __init__(self):
        Error.__init__(self, 'Outdated/no version information found for '\
                       'definitions. Please update to the latest version.')


class MorphologyDumper(yaml.SafeDumper):

    keyorder = (
        'name',
        'kind',
        'description',
        'arch',
        'strata',
        'configuration-extensions',
        'morph',
        'repo',
        'ref',
        'unpetrify-ref',
        'build-depends',
        'build-mode',
        'artifacts',
        'max-jobs',
        'products',
        'chunks',
        'build-system',
        'pre-configure-commands',
        'configure-commands',
        'post-configure-commands',
        'pre-build-commands',
        'build-commands',
        'pre-test-commands',
        'test-commands',
        'post-test-commands',
        'post-build-commands',
        'pre-install-commands',
        'install-commands',
        'post-install-commands',
        'artifact',
        'include',
        'systems',
        'deploy-defaults',
        'deploy',
        'type',
        'location',
    )

    def _represent_dict(cls, dumper, mapping):
        return dumper.represent_mapping('tag:yaml.org,2002:map',
                                        cls._iter_in_global_order(mapping))

    def _iter_in_global_order(cls, mapping):
        for key in cls.keyorder:
            if key in mapping:
                yield key, mapping[key]
        for key in sorted(mapping.iterkeys()):
            if key not in cls.keyorder:
                yield key, mapping[key]

    def __init__(self, *args, **kwargs):
        yaml.SafeDumper.__init__(self, *args, **kwargs)
        self.add_representer(dict, self._represent_dict)


class HyperlinkAddition():

    def version_check(self, file_name):
        try:
            f = open(file_name, 'r')
            try:
                obj = yaml.safe_load(f)
            except:
                raise YamlLoadError(file_name)
            if not isinstance(obj, dict):
                raise InvalidFormatError(file_name)
            version_number = obj['version']
            f.close()
            return version_number
        except:
            raise VersionNotFound()
        return '0'

    def set_url(self, upstream, repo, modifier, text):
        base_url = 'http://git.baserock.org/cgi-bin/cgit.cgi/%s/%s.git%s' % (
            upstream, repo, modifier)
        url = '<a href=\"%s\">%s</a>' % (base_url, text)
        return url

    def load_morphology(self, file_name):
        with open(file_name, 'r') as f:
            try:
                obj = yaml.safe_load(f)
            except:
                raise YamlLoadError(file_name)
            if not isinstance(obj, dict):
                raise InvalidFormatError(file_name)
            f.close()
        return obj

    def format_hyperlink(self, morphology):
        for chunk in morphology['chunks']:
            if 'baserock:' in chunk['repo']:
                repo = re.sub('baserock:', '', chunk['repo'])
                upstream = 'baserock'
            else:
                repo = re.sub('upstream:', '', chunk['repo'])
                upstream = 'delta'
            repo_url = self.set_url(upstream, repo, '', chunk['repo'])
            ref_url = self.set_url(upstream, repo, ('/commit/?id=%s' %
                                   chunk['ref']),
                                   chunk['ref'])
            u_ref_url = self.set_url(upstream, repo, ('/log/?h=%s' %
                                     chunk['unpetrify-ref']),
                                     chunk['unpetrify-ref'])
            chunk['repo'] = repo_url
            chunk['ref'] = ref_url
            chunk['unpetrify-ref'] = u_ref_url

    def main(self):
        if self.version_check('VERSION') < 6:
            raise VersionNotFound()

        for roots, dirs, files in os.walk(os.getcwd()):
            for morphology in files:
                if morphology.endswith('.morph'):
                    file_in = os.path.join(roots, morphology)
                    obj = self.load_morphology(file_in)
                    if obj['kind'] == 'stratum':
                        # Reformat each repo, ref and unpetrify-ref value in
                        # dict with the URL-formatted version
                        self.format_hyperlink(obj)
                        file_out = '%s.tmp' % file_in
                        with open(file_out, 'w') as f:
                            f.write(yaml.dump(obj, Dumper=MorphologyDumper,
                                              default_flow_style=False))
                            f.close()
                        move(file_out, file_in)
                    else:
                        # Morphology is not stratum; ignore
                        pass

if __name__ == "__main__":
    HyperlinkAddition().main()

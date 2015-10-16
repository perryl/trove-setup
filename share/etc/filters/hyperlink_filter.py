import os
from shutil import move
import subprocess

def set_url(upstream, repo, modifier, text):
    base_url = 'http://git.baserock.org/%s/%s.git%s' % (
        upstream, repo, modifier)
    url = '<a href=\"%s\">%s</a>' % (base_url, text)
    return url

def add_hyperlink():
    for morphology in os.listdir('strata'):
        source_file = ''.join(['strata/', morphology])
        url_file = ''.join(['strata/', morphology, '.tmp'])
        if morphology.endswith('.morph'):
            fin = open(source_file, 'r')
            fout = open(url_file, 'wt')
            lines = fin.readlines()
            for i in range (0, len(lines)):
                line = lines[i]
                if 'repo' in line:
                    upstream = ''
                    if 'upstream' in line:
                        upstream = 'delta'
                    else:
                        upstream = 'baserock/baserock'
                    repo = line[17:(len(line) - 1)]
                    # Cut off preceeding `  repo: upstream: | baserock:` and
                    # successive new line
                    repo_url = set_url(upstream, repo, '', repo)
                    fout.write(line.replace(repo, repo_url))
                    line = lines[i+1]

                    ref = line[7:(len(line) - 1)]
                    ref_url = set_url(upstream, repo, ('/commit/?id=%s' % ref),
                              ref)
                    fout.write(line.replace(ref, ref_url))
                    line = lines[i+2]

                    u_ref = line[17:(len(line) - 1)]
                    u_ref_url = set_url(upstream, repo, ('/log/?h=%s' % u_ref),
                                u_ref)
                    fout.write(line.replace(u_ref, u_ref_url))
                    i += 3
                elif 'ref' in line:
                    pass
                else:
                    fout.write(line)
            fin.close()
            fout.close()
            move(url_file, source_file)

add_hyperlink()

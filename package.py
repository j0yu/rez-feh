name = 'feh'

version = '3.1.3'

build_command = '''
set -euf -o pipefail

cp -v $REZ_BUILD_SOURCE_PATH/Dockerfile .
docker build --rm \
    --build-arg VERSION={version} \
    --build-arg PREFIX={install_dir} \
    -t local/feh .

if [ $REZ_BUILD_INSTALL -eq 1 ]
then
    CONTAINTER_ID=$(docker run --rm -td local/feh)
    docker cp $CONTAINTER_ID:{install_dir}/. {install_dir}
    docker stop $CONTAINTER_ID
fi
'''.format(
    version=version,
    install_dir='${{REZ_BUILD_INSTALL_PATH:-/usr/local}}',
)


def commands():
    import os.path
    env.PATH.append(os.path.join('{root}', 'bin'))
    env.LD_LIBRARY_PATH.append(os.path.join('{root}', 'lib'))
    env.XDG_DATA_DIRS.append(os.path.join('{root}', 'share'))


@late()
def tools():
    import os
    bin_path = os.path.join(str(this.root), 'bin')
    return os.listdir(bin_path)


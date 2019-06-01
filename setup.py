from setuptools import setup, find_packages, Extension
from setuptools.command.build_py import build_py

from distutils import dist
import distutils.command.install as dist_install

API_VER='6.3.13'
API_DIR='api/' + API_VER

def get_install_data_dir():
    d = dist.Distribution()
    install_cmd = dist_install.install(d)
    install_cmd.finalize_options()
    return install_cmd.install_data

class BuildPy(build_py):
    def run(self):
        self.run_command('build_ext')
        return super().run()

CTP_EXT = Extension(
    'ctp/_ctp',
    #['ctp/ctp.i'],
    ['ctp/ctp_wrap.cpp'],
    include_dirs=[API_DIR],
    library_dirs=[API_DIR],
    runtime_library_dirs=[get_install_data_dir() + '/ctp'],
    libraries=['thostmduserapi_se', 'thosttraderapi_se'],
    language='c++',
    #swig_opts=['-py3', '-c++', '-threads', '-I./' + API_DIR],
)

print(find_packages('.'))

setup(
    name='ctp',
    version=API_VER,
    author='Keli Hu',
    author_email='dev@keli.hu',
    description="""CTP for python""",
    ext_modules=[CTP_EXT],
    packages=['ctp'],
    package_dir={'ctp': 'ctp'},
    data_files=[('ctp', [API_DIR + '/libthostmduserapi_se.so', API_DIR + '/libthosttraderapi_se.so'])],
    classifiers=[
        'License :: OSI Approved :: BSD License',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: Implementation :: CPython',
    ],
    cmdclass={
        'build_py': BuildPy,
    },
)

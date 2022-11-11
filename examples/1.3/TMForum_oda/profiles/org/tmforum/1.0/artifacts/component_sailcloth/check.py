import yaml
import os
import argparse
import subprocess
import glob

#Abortive attempt to create an oda component similator. Might be useful for writting a checker for topology of the new emulatr solution

def extract_apis(component_yaml):
    # takes a a path to a component yaml file and returns a dict of caps and reqs
    with open(component_yaml) as f:
        docs = yaml.safe_load_all(f)
        for doc in docs:
            if doc["kind"] == 'component':
                caps=doc['spec']['coreFunction']['exposedAPIs']
                reqs=doc['spec']['coreFunction']['dependantAPIs']
                # for cap in caps:
                #     print(cap['name'])
                # for req in reqs:
                #     print(req['name'])
    return {'caps': caps, 'reqs': reqs}

def get_filename():
    real_path = os.path.realpath(__file__)
    dir_path = os.path.dirname(real_path)
    return(dir_path+'/'+'component.yaml')

def search_files(caps):
    # search local files containing python programs like like
    # ask each one if it can support requirement
    real_path = os.path.realpath(__file__)
    dir_path = os.path.dirname(real_path)
    files = glob.glob(dir_path+"/*.py",recursive=False)
    #files = (os.listdir(dir_path))
    for cap in caps:
        print(cap['name'])
        req_found=False
        for file in files:
            print(file)
            #command_str="+file+" -r "+cap['name']
            command_str="python3 ~/Workspace/tosca/profiles/org/tmforum/1.0/artifacts/proxy/comp1.py"
            if subprocess.run([command_str], shell=True):
                # this cap has been matched with an external req
                req_found=True
                # no need to look in further files
                break
        # no need to check other caps as we already have a match failure
        break

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument('-r', '--requirement',
                    default='defaultvalue',
                    dest='req',
                    help='Provide a requirement name to see if this module provides it',
                    type=str
                    )
    args = parser.parse_args()
    print(f'The req is "{args.req}"')

    apis=extract_apis(get_filename())
    caps=apis["caps"]
    return(search_files(caps))

if __name__ == "__main__":
    exit(main())
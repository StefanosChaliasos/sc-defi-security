import os
import datetime
import json

from collections import defaultdict

from result_parsing.result import Result


def find_json(path):
    # Now we select result.json
    jsons = [f for f in os.listdir(path) if f.endswith('.json')]
    assert len(jsons) > 0, path
    if len(jsons) > 1:
        return os.path.join(path, "result.json")
    return os.path.join(path, jsons[0])


class Base:
    vulns_map = {}
    fails = []
    errors = []

    def __init__(self, path, bytecode, contract):
        self.name = self.__class__.__name__.lower()
        self.path = path
        self.bytecode = bytecode
        self.contract = contract
        if len(self.__class__.vulns_map) == 0:
            raise NotImplementedError(f"vulns_map is not set for {self.name}")
        self.vulns_map = self.__class__.vulns_map
        self.contracts = {}  # contract => results.json path
        self.results = {}  # contract => Result

        self._set_contracts()

    def _set_contracts(self):
        tool_path = os.path.join(self.path, self.name)
        # it could raise FileNotFoundError if analysis does not exist
        runs = [d for d in os.listdir(tool_path) if not d.startswith('.')]
        for run in runs:
            run_path = os.path.join(tool_path, run)
            if self.contract:
                results_path = find_json(os.path.join(run_path, self.contract))
                assert os.path.isfile(results_path)
                self.contracts[self.contract] = results_path
            else:
                contracts = [c for c in os.listdir(run_path) if c.startswith("0x")]
                for contract in contracts:
                    results_path = find_json(os.path.join(run_path, contract))
                    assert os.path.isfile(results_path), results_path
                    assert contract not in self.contracts, f"Contract {contract} analyzed twice"
                    self.contracts[contract] = results_path

    def process_analysis(self, analysis, output, findings):
        raise NotImplementedError

    def parse_contract_results(self, result_path):
        vulnerabilities = {}
        total_time = 0
        error = False

        output = defaultdict(lambda: 0)
        with open(result_path, 'r') as f:
            result = json.load(f)
            # total_time = result['duration']
            if 'findings' in result:
                findings = result.get('findings', None)
                if result['findings'] is not None and len(result['findings']) > 0:
                    self.process_analysis(result['findings'], output, findings)
                # If there are findings and then errors, do not count it as error
                elif 'errors' in result and result['errors'] is not None:
                    if len(result['errors']) > 0:
                        error = True
                        # Check that this is a known error
                        if (not any(e for e in result.get('fails', [])
                                    if any(f in e for f in self.fails)) and
                                not any(e for e in result.get('errors', [])
                                        if any(f in e for f in self.errors))):
                            raise Exception("Unknown Error: (fails: {}), (errors: {})".format(result.get('fails'),
                                                                                              result.get('errors')))
                        # print("(fails: {}), (errors: {})".format(result.get('fails'), result.get('errors')))
            else:
                # This is the case where we analyse smartbugs.json
                # create an assertion for results.json
                # What does it mean when there is no results.json
                raise Exception("We shouldn't be here")

        execution_time = str(datetime.timedelta(seconds=round(total_time)))
        vulnerabilities = self.canonicalizer(output)
        return Result(execution_time, vulnerabilities, error)

    def canonicalizer(self, output):
        vulnerabilities = {}
        for vuln, occ in output.items():
            if vuln not in self.vulns_map:
                exception_message = f"{self.name}: {vuln} not in {self.vulns_map.keys()}"
                raise Exception(exception_message)
            if occ > 0:
                vulnerabilities[self.vulns_map[vuln]] = occ
        return vulnerabilities

    def parse(self):
        result = {}
        for contract, path in self.contracts.items():
            result[contract] = self.parse_contract_results(path)
        return result

class Result:
    def __init__(self, execution_time, vulnerabilities, error=False):
        self.execution_time = execution_time
        self.vulnerabilities = vulnerabilities
        self.total_vulnerabilities = sum(v for v in vulnerabilities.values())
        self.error = error

    def __repr__(self):
        vulns = ", ".join(self.vulnerabilities.keys())
        s = ""
        if vulns == "":
            s = f"{self.execution_time} -- None"
        else:
            s = f"{self.execution_time} -- {vulns} ({self.total_vulnerabilities})"
        return f"Result({s})"

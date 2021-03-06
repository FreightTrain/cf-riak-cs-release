package cf_test

import (
	"os/exec"

	. "github.com/cloudfoundry-incubator/cf-test-helpers/cf"
	"github.com/cloudfoundry-incubator/cf-test-helpers/runner"
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	. "github.com/onsi/gomega/gexec"
)

var _ = Describe("Cf", func() {
	It("sends the request to current CF target", func() {
		runner.CommandInterceptor = func(cmd *exec.Cmd) *exec.Cmd {
			Expect(cmd.Path).To(Equal(exec.Command("gcf").Path))
			Expect(cmd.Args).To(Equal([]string{"gcf", "apps"}))

			return exec.Command("bash", "-c", `exit 42`)
		}

		Eventually(Cf("apps")).Should(Exit(42))
	})
})

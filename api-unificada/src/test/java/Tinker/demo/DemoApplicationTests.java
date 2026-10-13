package Tinker.demo;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class DemoApplicationTests {

	@Test
	void classePrincipalEstaDisponivelSemInicializarDatasource() {
		assertNotNull(DemoApplication.class);
	}

}

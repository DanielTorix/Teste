/**
 * Copyright (c) 2014, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
@isTest
private class FW_IDGeneratorTest {
	@isTest
	static void itShouldGenerateValidIDs() {
		String id1 = FW_IDGenerator.generate(Account.SObjectType);
		String id2 = FW_IDGenerator.generate(Account.SObjectType);
		String id3 = FW_IDGenerator.generate(Account.SObjectType);
		String id4 = FW_IDGenerator.generate(Account.SObjectType);
		String id5 = FW_IDGenerator.generate(Account.SObjectType);
		String id6 = FW_IDGenerator.generate(Account.SObjectType);
		String id7 = FW_IDGenerator.generate(Account.SObjectType);
		String id8 = FW_IDGenerator.generate(Account.SObjectType);
		String id9 = FW_IDGenerator.generate(Account.SObjectType);
		String id10 = FW_IDGenerator.generate(Account.SObjectType);
		String id11 = FW_IDGenerator.generate(Account.SObjectType);

		String id1Test = '001000000000001AAA';//NOSONAR
		String id2Test = '001000000000002AAA';//NOSONAR
		String id3Test = '001000000000003AAA';//NOSONAR
		String id4Test = '001000000000004AAA';//NOSONAR
		String id5Test = '001000000000005AAA';//NOSONAR
		String id6Test = '001000000000006AAA';//NOSONAR
		String id7Test = '001000000000007AAA';//NOSONAR
		String id8Test = '001000000000008AAA';//NOSONAR
		String id9Test = '001000000000009AAA';//NOSONAR
		String id10Test = '001000000000010AAA';//NOSONAR
		String id11Test = '001000000000011AAA';//NOSONAR
		
		System.assertEquals(id1Test, id1);
		System.assertEquals(id2Test, id2);
		System.assertEquals(id3Test, id3);
		System.assertEquals(id4Test, id4);
		System.assertEquals(id5Test, id5);
		System.assertEquals(id6Test, id6);
		System.assertEquals(id7Test, id7);
		System.assertEquals(id8Test, id8);
		System.assertEquals(id9Test, id9);
		System.assertEquals(id10Test, id10);
		System.assertEquals(id11Test, id11);
	}
}
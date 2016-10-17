package main;

public class Transition {

	/**
	 * 
	 * @param P	wzorzec
	 * @param A	alfabet
	 * @return	funkcja przejœæ
	 */
	public int[][] computeTransitionFunction(String P, char[] E){
		int m = P.length();
		int k, q;
		int[][] d = new int[m + 1][E.length];
		
		for(q = 0; q <= m; q++){
			for(char e : E){
				k = Math.min(m + 1, q + 2);

				do{
					k--;
				}while(!(P.substring(0, q) + Character.toString(e)).endsWith(P.substring(0, k)));
				
				d[q][e-33] = k;
			}
		}
		print(d, E);
		return d;
	}


	private void print(int[][] d, char[] E) {
		System.out.print("    ");
		for (char a : E){
			System.out.print(a + "  ");		
		}
		System.out.println();
		for(int i = 0; i < d.length; i++){
			System.out.print(i + ": ");
			if(i < 10) System.out.print(" ");
			for(int j = 0; j < d[i].length; j++){
				System.out.print(d[i][j] + " ");
				if(d[i][j] < 10) System.out.print(" ");
			}
			System.out.println();
		}
		
	}
}
